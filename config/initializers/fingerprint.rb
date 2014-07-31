require File.join(Rails.root, 'app', 'models', 'fingerprints', 'simplistic_fingerprint')

ErrorReport.fingerprint_strategy = SimplisticFingerprint
