"""
NutriShare ML Core Module

Behavior-Based Nutrition Recommendation System
Uses: Decision Tree (diet status) + K-Means (behavior pattern)

Author: NutriShare Team
"""

import numpy as np
import pandas as pd
from sklearn.tree import DecisionTreeClassifier
from sklearn.cluster import KMeans
from sklearn.preprocessing import StandardScaler
from sklearn.model_selection import train_test_split
from sklearn.metrics import classification_report
import joblib
import json
from dataclasses import dataclass
from typing import Optional
import warnings
warnings.filterwarnings("ignore")
import sys
import io

sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8')
sys.stderr = io.TextIOWrapper(sys.stderr.buffer, encoding='utf-8')



# 1. DATA STRUCTURES
 

@dataclass
class UserProfile:
    """Represents a user's static profile data."""
    age: int
    weight_kg: float
    height_cm: float
    activity_level: str   # sedentary, light, moderate, active, very_active
    goal: str             # lose_weight, maintain, gain_muscle

@dataclass
class DailyLog:
    """Represents a single day's food log."""
    date: str
    calories: float
    protein_g: float
    carbs_g: float
    fat_g: float
    meal_count: int       # number of distinct meals logged



# 2. FEATURE ENGINEERING


class FeatureEngineer:
    """
    Transforms raw user profile + daily logs into ML-ready features.

    Diet Status Features (per day):
    - calorie_ratio          : actual / target calories
    - protein_ratio          : actual / target protein
    - carb_ratio             : actual / target carbs
    - fat_ratio              : actual / target fat
    - meal_count             : number of meals logged

    Behavior Pattern Features (aggregated over N days):
    - avg_calorie_ratio      : mean calorie adherence
    - calorie_consistency    : std deviation of calorie ratio (lower = more consistent)
    - avg_protein_ratio      : mean protein adherence
    - avg_carb_ratio         : mean carb adherence
    - avg_fat_ratio          : mean fat adherence
    - logging_frequency      : days logged / total days in window
    - avg_meal_count         : average meals per day
    """

    ACTIVITY_MULTIPLIERS = {
        "sedentary":   1.2,
        "light":       1.375,
        "moderate":    1.55,
        "active":      1.725,
        "very_active": 1.9,
    }

    GOAL_CALORIE_ADJUSTMENT = {
        "lose_weight":  -500,
        "maintain":     0,
        "gain_muscle":  +300,
    }

    def calculate_bmr(self, profile: UserProfile) -> float:
        """Mifflin-St Jeor equation for Basal Metabolic Rate."""
        bmr = (10 * profile.weight_kg
               + 6.25 * profile.height_cm
               - 5 * profile.age
               + 5)   # Using male formula; adjust -161 for female
        return bmr

    def calculate_targets(self, profile: UserProfile) -> dict:
        """Calculate daily macro targets from user profile."""
        bmr = self.calculate_bmr(profile)
        multiplier = self.ACTIVITY_MULTIPLIERS.get(profile.activity_level, 1.55)
        tdee = bmr * multiplier
        calorie_target = tdee + self.GOAL_CALORIE_ADJUSTMENT.get(profile.goal, 0)

        # Standard macro split: 30% protein, 40% carbs, 30% fat
        protein_target = (calorie_target * 0.30) / 4   # 4 kcal/g
        carb_target    = (calorie_target * 0.40) / 4   # 4 kcal/g
        fat_target     = (calorie_target * 0.30) / 9   # 9 kcal/g

        return {
            "calories": calorie_target,
            "protein_g": protein_target,
            "carbs_g": carb_target,
            "fat_g": fat_target,
        }

    def extract_daily_features(self, log: DailyLog, targets: dict) -> dict:
        """Extract per-day features normalized against personal targets."""
        return {
            "calorie_ratio":  log.calories   / targets["calories"],
            "protein_ratio":  log.protein_g  / targets["protein_g"],
            "carb_ratio":     log.carbs_g    / targets["carbs_g"],
            "fat_ratio":      log.fat_g      / targets["fat_g"],
            "meal_count":     log.meal_count,
        }

    def extract_behavior_features(self, daily_features_list: list, window_days: int = 7) -> dict:
        """
        Aggregate daily features into long-term behavior pattern features.
        window_days: how many days to consider (default 7 = last week)
        """
        df = pd.DataFrame(daily_features_list)

        # Pad if fewer days than window
        logging_frequency = len(df) / window_days

        return {
            "avg_calorie_ratio":     df["calorie_ratio"].mean(),
            "calorie_consistency":   df["calorie_ratio"].std(ddof=0),  # 0 = consistent
            "avg_protein_ratio":     df["protein_ratio"].mean(),
            "avg_carb_ratio":        df["carb_ratio"].mean(),
            "avg_fat_ratio":         df["fat_ratio"].mean(),
            "logging_frequency":     logging_frequency,
            "avg_meal_count":        df["meal_count"].mean(),
        }


# ─────────────────────────────────────────────
# 3. SYNTHETIC DATASET GENERATION
# ─────────────────────────────────────────────

def generate_training_data(n_samples: int = 1000, seed: int = 42) -> tuple:
    """
    Generate synthetic training data for both models.

    Diet Status Labels (Decision Tree target):
    - "on_track"     : balanced intake close to target
    - "over_eating"  : calories significantly above target
    - "under_eating" : calories significantly below target
    - "imbalanced"   : calories ok but macros are off

    Returns: (diet_df, behavior_df)
    """
    np.random.seed(seed)

    # ── Diet Status Dataset ──────────────────
    diet_records = []
    diet_labels = []

    for _ in range(n_samples):
        cal_ratio  = np.random.uniform(0.4, 1.8)
        prot_ratio = np.random.uniform(0.3, 2.0)
        carb_ratio = np.random.uniform(0.3, 2.0)
        fat_ratio  = np.random.uniform(0.3, 2.0)
        meal_count = np.random.randint(1, 6)

        # Label logic (reflects real nutritional rules)
        if cal_ratio > 1.20:
            label = "over_eating"
        elif cal_ratio < 0.75:
            label = "under_eating"
        elif (prot_ratio < 0.70 or prot_ratio > 1.40 or
              carb_ratio < 0.70 or carb_ratio > 1.40 or
              fat_ratio  < 0.70 or fat_ratio  > 1.40):
            label = "imbalanced"
        else:
            label = "on_track"

        # Add noise
        cal_ratio  += np.random.normal(0, 0.05)
        prot_ratio += np.random.normal(0, 0.05)

        diet_records.append({
            "calorie_ratio": round(cal_ratio, 3),
            "protein_ratio": round(prot_ratio, 3),
            "carb_ratio":    round(carb_ratio, 3),
            "fat_ratio":     round(fat_ratio, 3),
            "meal_count":    meal_count,
        })
        diet_labels.append(label)

    diet_df = pd.DataFrame(diet_records)
    diet_df["label"] = diet_labels

    # ── Behavior Pattern Dataset ─────────────
    behavior_records = []

    for _ in range(n_samples):
        # Simulate 4 natural behavior archetypes
        archetype = np.random.choice(["disciplined", "inconsistent", "sedentary_overeater", "under_fueled"])

        if archetype == "disciplined":
            behavior_records.append({
                "avg_calorie_ratio":   np.random.normal(1.0, 0.08),
                "calorie_consistency": np.random.uniform(0.0, 0.12),
                "avg_protein_ratio":   np.random.normal(1.0, 0.10),
                "avg_carb_ratio":      np.random.normal(1.0, 0.10),
                "avg_fat_ratio":       np.random.normal(1.0, 0.10),
                "logging_frequency":   np.random.uniform(0.85, 1.0),
                "avg_meal_count":      np.random.uniform(3.0, 5.0),
            })
        elif archetype == "inconsistent":
            behavior_records.append({
                "avg_calorie_ratio":   np.random.normal(1.05, 0.15),
                "calorie_consistency": np.random.uniform(0.25, 0.55),
                "avg_protein_ratio":   np.random.normal(0.95, 0.20),
                "avg_carb_ratio":      np.random.normal(1.05, 0.20),
                "avg_fat_ratio":       np.random.normal(1.05, 0.20),
                "logging_frequency":   np.random.uniform(0.40, 0.75),
                "avg_meal_count":      np.random.uniform(2.0, 4.0),
            })
        elif archetype == "sedentary_overeater":
            behavior_records.append({
                "avg_calorie_ratio":   np.random.normal(1.35, 0.15),
                "calorie_consistency": np.random.uniform(0.05, 0.20),
                "avg_protein_ratio":   np.random.normal(0.80, 0.15),
                "avg_carb_ratio":      np.random.normal(1.50, 0.15),
                "avg_fat_ratio":       np.random.normal(1.40, 0.15),
                "logging_frequency":   np.random.uniform(0.50, 0.80),
                "avg_meal_count":      np.random.uniform(2.0, 3.5),
            })
        else:  # under_fueled
            behavior_records.append({
                "avg_calorie_ratio":   np.random.normal(0.65, 0.10),
                "calorie_consistency": np.random.uniform(0.05, 0.20),
                "avg_protein_ratio":   np.random.normal(0.60, 0.15),
                "avg_carb_ratio":      np.random.normal(0.70, 0.15),
                "avg_fat_ratio":       np.random.normal(0.65, 0.15),
                "logging_frequency":   np.random.uniform(0.60, 0.90),
                "avg_meal_count":      np.random.uniform(1.5, 3.0),
            })

    behavior_df = pd.DataFrame(behavior_records).clip(lower=0)

    return diet_df, behavior_df


# ─────────────────────────────────────────────
# 4. MODEL TRAINING
# ─────────────────────────────────────────────

class DietStatusClassifier:
    """
    Decision Tree classifier for short-term (daily) diet status.

    Why Decision Tree?
    - Fully interpretable: you can print the tree rules
    - No black box: every decision has a clear if/else path
    - Handles non-linear boundaries without scaling
    - Easy to explain to non-technical stakeholders
    """

    FEATURES = ["calorie_ratio", "protein_ratio", "carb_ratio", "fat_ratio", "meal_count"]
    CLASSES   = ["on_track", "over_eating", "under_eating", "imbalanced"]

    def __init__(self, max_depth: int = 5):
        self.model = DecisionTreeClassifier(
            max_depth=max_depth,
            min_samples_leaf=10,
            random_state=42
        )
        self.is_trained = False

    def train(self, diet_df: pd.DataFrame) -> dict:
        """Train and return evaluation metrics."""
        X = diet_df[self.FEATURES]
        y = diet_df["label"]

        X_train, X_test, y_train, y_test = train_test_split(
            X, y, test_size=0.2, random_state=42, stratify=y
        )

        self.model.fit(X_train, y_train)
        self.is_trained = True

        y_pred = self.model.predict(X_test)
        report = classification_report(y_test, y_pred, output_dict=True)
        print("✅ Diet Status Classifier trained.")
        print(f"   Accuracy: {report['accuracy']:.2%}")
        return report

    def predict(self, features: dict) -> tuple[str, dict]:
        """
        Returns (predicted_label, probabilities_dict).
        """
        if not self.is_trained:
            raise RuntimeError("Model not trained. Call train() first.")
        X = pd.DataFrame([features])[self.FEATURES]
        label = self.model.predict(X)[0]
        proba = self.model.predict_proba(X)[0]
        proba_dict = dict(zip(self.model.classes_, proba.round(3)))
        return label, proba_dict

    def save(self, path: str = "models/diet_classifier.pkl"):
        joblib.dump(self.model, path)
        print(f"💾 Diet classifier saved to {path}")

    def load(self, path: str = "models/diet_classifier.pkl"):
        self.model = joblib.load(path)
        self.is_trained = True


class BehaviorPatternDetector:
    """
    K-Means clustering for long-term behavior pattern analysis.

    Why K-Means?
    - Unsupervised: no need for labeled behavior data
    - Groups users into meaningful archetypes naturally
    - Centroids are interpretable as "average user profiles"
    - Simple to understand: each user belongs to the nearest centroid

    Clusters (learned, but mapped to human labels post-hoc):
    0: Disciplined Tracker
    1: Inconsistent Logger
    2: Habitual Overeater
    3: Chronically Under-fueled
    """

    FEATURES = [
        "avg_calorie_ratio", "calorie_consistency",
        "avg_protein_ratio", "avg_carb_ratio", "avg_fat_ratio",
        "logging_frequency", "avg_meal_count"
    ]

    CLUSTER_LABELS = {
        0: "disciplined_tracker",
        1: "inconsistent_logger",
        2: "habitual_overeater",
        3: "chronically_under_fueled",
    }

    def __init__(self, n_clusters: int = 4):
        self.n_clusters = n_clusters
        self.scaler = StandardScaler()
        self.model = KMeans(n_clusters=n_clusters, random_state=42, n_init=10)
        self.is_trained = False

    def train(self, behavior_df: pd.DataFrame):
        """Fit scaler and K-Means on behavior data."""
        X = behavior_df[self.FEATURES]
        X_scaled = self.scaler.fit_transform(X)
        self.model.fit(X_scaled)
        self.is_trained = True

        # Map cluster IDs to human labels based on centroid interpretation
        self._map_clusters(behavior_df, X_scaled)
        print(f"✅ Behavior Pattern Detector trained with {self.n_clusters} clusters.")
        print(f"   Cluster mapping: {self.cluster_map}")

    def _map_clusters(self, behavior_df: pd.DataFrame, X_scaled: np.ndarray):
        """
        Auto-map cluster IDs to human-readable labels
        by analyzing centroid characteristics.
        """
        labels = self.model.labels_
        behavior_df = behavior_df.copy()
        behavior_df["cluster"] = labels

        # For each cluster, compute mean calorie ratio and consistency
        summary = behavior_df.groupby("cluster").agg(
            avg_cal=("avg_calorie_ratio", "mean"),
            avg_consistency=("calorie_consistency", "mean"),
            avg_freq=("logging_frequency", "mean"),
        ).reset_index()

        self.cluster_map = {}
        for _, row in summary.iterrows():
            cid = int(row["cluster"])
            if row["avg_cal"] >= 1.20:
                self.cluster_map[cid] = "habitual_overeater"
            elif row["avg_cal"] <= 0.80:
                self.cluster_map[cid] = "chronically_under_fueled"
            elif row["avg_consistency"] >= 0.25 or row["avg_freq"] < 0.65:
                self.cluster_map[cid] = "inconsistent_logger"
            else:
                self.cluster_map[cid] = "disciplined_tracker"

    def predict(self, features: dict) -> tuple[str, int]:
        """Returns (behavior_label, cluster_id)."""
        if not self.is_trained:
            raise RuntimeError("Model not trained. Call train() first.")
        X = pd.DataFrame([features])[self.FEATURES]
        X_scaled = self.scaler.transform(X)
        cluster_id = int(self.model.predict(X_scaled)[0])
        behavior_label = self.cluster_map.get(cluster_id, "unknown")
        return behavior_label, cluster_id

    def save(self, scaler_path: str = "models/behavior_scaler.pkl",
             model_path: str  = "models/behavior_kmeans.pkl",
             map_path: str    = "models/cluster_map.json"):
        joblib.dump(self.scaler, scaler_path)
        joblib.dump(self.model,  model_path)
        with open(map_path, "w") as f:
            json.dump(self.cluster_map, f)
        print(f"💾 Behavior detector saved.")

    def load(self, scaler_path: str = "models/behavior_scaler.pkl",
             model_path: str  = "models/behavior_kmeans.pkl",
             map_path: str    = "models/cluster_map.json"):
        self.scaler = joblib.load(scaler_path)
        self.model  = joblib.load(model_path)
        with open(map_path) as f:
            raw = json.load(f)
            self.cluster_map = {int(k): v for k, v in raw.items()}
        self.is_trained = True


# ─────────────────────────────────────────────
# 5. FEEDBACK GENERATION
# ─────────────────────────────────────────────

class FeedbackGenerator:
    """
    Converts ML model outputs into simple, human-readable advice.
    Combines short-term diet status + long-term behavior pattern
    into a single, actionable recommendation bundle.
    """

    # ── Diet Status Messages ─────────────────
    DIET_MESSAGES = {
        "on_track": {
            "status":  "✅ Great job today!",
            "summary": "Your intake is well-balanced and close to your personal targets.",
            "tip":     "Keep it up — consistency is the key to reaching your goal.",
        },
        "over_eating": {
            "status":  "⚠️ You exceeded your calorie target today.",
            "summary": "Your total calories are noticeably above your daily goal.",
            "tip":     "Try smaller portions or choose lower-calorie snacks tomorrow.",
        },
        "under_eating": {
            "status":  "⚠️ You ate too little today.",
            "summary": "Your calorie intake was significantly below your goal.",
            "tip":     "Undereating can slow your metabolism. Add a healthy snack or an extra meal.",
        },
        "imbalanced": {
            "status":  "⚠️ Your macros are out of balance today.",
            "summary": "Calories look okay, but protein, carbs, or fat is off target.",
            "tip":     "Try to include a protein source (eggs, tofu, chicken) in every meal.",
        },
    }

    # ── Behavior Pattern Messages ─────────────
    BEHAVIOR_MESSAGES = {
        "disciplined_tracker": {
            "pattern": "You are a Disciplined Tracker.",
            "insight": "You log consistently and your intake is stable week over week.",
            "action":  "Consider fine-tuning your macros for even better results.",
        },
        "inconsistent_logger": {
            "pattern": "You are an Inconsistent Logger.",
            "insight": "Your intake varies a lot from day to day and your logging is irregular.",
            "action":  "Try setting a daily reminder to log your meals — even estimates count!",
        },
        "habitual_overeater": {
            "pattern": "You tend to eat above your calorie target most days.",
            "insight": "Your weekly average is consistently above your goal.",
            "action":  "Start with one swap per day — e.g., replace a sugary drink with water.",
        },
        "chronically_under_fueled": {
            "pattern": "You tend to eat below your calorie target most days.",
            "insight": "Consistent undereating can cause fatigue and muscle loss.",
            "action":  "Add calorie-dense but nutritious foods: nuts, avocado, legumes.",
        },
    }

    def generate(self, diet_status: str, behavior_pattern: str,
                 targets: dict, actuals: dict) -> dict:
        """
        Combine both model outputs into a structured feedback bundle.

        Parameters:
            diet_status      : output from DietStatusClassifier
            behavior_pattern : output from BehaviorPatternDetector
            targets          : computed calorie/macro targets
            actuals          : today's actual intake values
        """
        diet_fb     = self.DIET_MESSAGES.get(diet_status, {})
        behavior_fb = self.BEHAVIOR_MESSAGES.get(behavior_pattern, {})

        # Numeric gap summaries
        cal_gap = actuals["calories"] - targets["calories"]
        prot_gap = actuals["protein_g"] - targets["protein_g"]

        gap_description = (
            f"Today you ate {abs(cal_gap):.0f} kcal "
            f"{'more' if cal_gap > 0 else 'less'} than your target. "
            f"Protein was {abs(prot_gap):.0f}g "
            f"{'above' if prot_gap > 0 else 'below'} goal."
        )

        return {
            "today": {
                "diet_status":  diet_status,
                "status_label": diet_fb.get("status", ""),
                "summary":      diet_fb.get("summary", ""),
                "gap":          gap_description,
                "tip":          diet_fb.get("tip", ""),
            },
            "weekly": {
                "behavior_pattern": behavior_pattern,
                "pattern_label":    behavior_fb.get("pattern", ""),
                "insight":          behavior_fb.get("insight", ""),
                "action":           behavior_fb.get("action", ""),
            },
            "combined_advice": self._combine_advice(diet_status, behavior_pattern),
        }

    def _combine_advice(self, diet_status: str, behavior_pattern: str) -> str:
        """
        Generate one final combined sentence that bridges today + weekly pattern.
        """
        combos = {
            ("on_track",    "disciplined_tracker"):      "Excellent work — your habits are aligned with your goals!",
            ("on_track",    "inconsistent_logger"):      "Today was great! Try to replicate this consistency every day.",
            ("on_track",    "habitual_overeater"):       "Great day! Keep this up — you're breaking a tough habit.",
            ("on_track",    "chronically_under_fueled"): "Nice recovery today. Aim to sustain this intake level.",
            ("over_eating", "disciplined_tracker"):      "Rare slip — just get back on track tomorrow. You've got this.",
            ("over_eating", "inconsistent_logger"):      "Try to plan your meals in advance to avoid overeating.",
            ("over_eating", "habitual_overeater"):       "This is a recurring pattern. Small daily reductions add up.",
            ("over_eating", "chronically_under_fueled"): "Consider spreading meals throughout the day for better balance.",
            ("under_eating","disciplined_tracker"):      "Don't skip meals — fuel your body to support your progress.",
            ("under_eating","inconsistent_logger"):      "Irregular eating makes tracking hard. Try 3 fixed meal times.",
            ("under_eating","habitual_overeater"):       "Good restraint! Aim to stay in range rather than going too low.",
            ("under_eating","chronically_under_fueled"): "Consistent undereating is a concern. Consider consulting a dietitian.",
            ("imbalanced",  "disciplined_tracker"):      "Your habits are solid — just fine-tune your macro distribution.",
            ("imbalanced",  "inconsistent_logger"):      "Work on logging consistently to better understand your patterns.",
            ("imbalanced",  "habitual_overeater"):       "Focus on protein-rich foods to improve your macro balance.",
            ("imbalanced",  "chronically_under_fueled"): "Add more diverse foods to hit both your calories and macros.",
        }
        key = (diet_status, behavior_pattern)
        return combos.get(key, "Keep logging every day — data is your best nutritional guide.")


# ─────────────────────────────────────────────
# 6. PREDICTION PIPELINE (INFERENCE)
# ─────────────────────────────────────────────

class NutriShareRecommender:
    """
    End-to-end inference pipeline:
    User Profile + Daily Logs → Features → Models → Feedback
    """

    def __init__(self):
        self.engineer   = FeatureEngineer()
        self.classifier = DietStatusClassifier()
        self.detector   = BehaviorPatternDetector()
        self.feedback   = FeedbackGenerator()

    def load_models(self):
        self.classifier.load()
        self.detector.load()

    def recommend(self, profile: UserProfile,
                  today_log: DailyLog,
                  history_logs: list[DailyLog]) -> dict:
        """
        Full recommendation pipeline.

        Parameters:
            profile       : user's static profile
            today_log     : today's food log
            history_logs  : list of DailyLog for past N days (ideally 7)

        Returns: Complete feedback bundle dict
        """
        # Step 1: Compute personal targets
        targets = self.engineer.calculate_targets(profile)

        # Step 2: Extract today's features
        today_features = self.engineer.extract_daily_features(today_log, targets)

        # Step 3: Extract behavior features from history
        history_features = [
            self.engineer.extract_daily_features(log, targets)
            for log in history_logs
        ]
        behavior_features = self.engineer.extract_behavior_features(
            history_features, window_days=7
        )

        # Step 4: Run both models
        diet_status, diet_proba      = self.classifier.predict(today_features)
        behavior_pattern, cluster_id = self.detector.predict(behavior_features)

        # Step 5: Generate human-readable feedback
        actuals = {
            "calories":  today_log.calories,
            "protein_g": today_log.protein_g,
            "carbs_g":   today_log.carbs_g,
            "fat_g":     today_log.fat_g,
        }
        feedback = self.feedback.generate(diet_status, behavior_pattern, targets, actuals)

        return {
            "targets":            targets,
            "today_features":     today_features,
            "diet_status":        diet_status,
            "diet_confidence":    diet_proba,
            "behavior_pattern":   behavior_pattern,
            "behavior_cluster_id": cluster_id,
            "feedback":           feedback,
        }


# ─────────────────────────────────────────────
# 7. TRAINING SCRIPT
# ─────────────────────────────────────────────

def train_all_models():
    """Run full training pipeline and save models."""
    import os
    os.makedirs("models", exist_ok=True)

    print("=" * 50)
    print("  NutriShare ML Training Pipeline")
    print("=" * 50)

    # Generate synthetic training data
    print("\nGenerating training data...")
    diet_df, behavior_df = generate_training_data(n_samples=2000)
    print(f"   Diet dataset: {len(diet_df)} samples")
    print(f"   Behavior dataset: {len(behavior_df)} samples")
    print(f"   Diet label distribution:\n{diet_df['label'].value_counts()}\n")

    # Train diet status classifier
    print(" Training Decision Tree (Diet Status)...")
    classifier = DietStatusClassifier(max_depth=5)
    classifier.train(diet_df)
    classifier.save()

    # Train behavior pattern detector
    print("\n Training K-Means (Behavior Pattern)...")
    detector = BehaviorPatternDetector(n_clusters=4)
    detector.train(behavior_df)
    detector.save()

    print("\n✅ All models trained and saved to /models")
    return classifier, detector


if __name__ == "__main__":
    # ── TRAIN ──────────────────────────────────
    classifier, detector = train_all_models()

    # ── DEMO INFERENCE ─────────────────────────
    print("\n" + "=" * 50)
    print("  Demo: Full Prediction Pipeline")
    print("=" * 50)

    recommender = NutriShareRecommender()
    recommender.classifier = classifier
    recommender.detector   = detector

    # Sample user
    profile = UserProfile(
        age=25, weight_kg=72, height_cm=175,
        activity_level="moderate", goal="lose_weight"
    )

    # Today's log
    today = DailyLog(
        date="2025-01-10",
        calories=2400, protein_g=65, carbs_g=310, fat_g=88,
        meal_count=3
    )

    # Past 7 days (simulated)
    import random
    history = [
        DailyLog(
            date=f"2025-01-0{i}",
            calories=random.randint(2200, 2800),
            protein_g=random.randint(55, 80),
            carbs_g=random.randint(270, 350),
            fat_g=random.randint(75, 100),
            meal_count=random.randint(2, 4)
        )
        for i in range(3, 10)
    ]

    result = recommender.recommend(profile, today, history)

    print(f"Diet Status:        {result['diet_status']}")
    print(f"Behavior Pattern:   {result['behavior_pattern']}")
    print(f"\nToday:  {result['feedback']['today']['status_label']}")
    print(f"   {result['feedback']['today']['tip']}")
    print(f"\nWeekly: {result['feedback']['weekly']['pattern_label']}")
    print(f"   {result['feedback']['weekly']['action']}")
    print(f"\nCombined: {result['feedback']['combined_advice']}")
