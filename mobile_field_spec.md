
# Mobile Field App - Change Order Workflow (from research page 5)

User Story: Contractor on jobsite finds rotted framing behind drywall

Flow:
1. Open project -> Active Milestone
2. Tap "Create Change Order"
3. Take photos (geotagged, cached offline)
4. Fill: Title, Reason, Cost Adjustment, Schedule Adjustment
5. Submit -> Pauses work on adjusted scope
6. Homeowner gets push: Approve + fund revised escrow
7. Work resumes only after approval

Tables used: change_orders, escrow_allocations (new allocation for delta)

Offline: Flutter Hive cache + background sync when connectivity returns (jobsite in basement)
