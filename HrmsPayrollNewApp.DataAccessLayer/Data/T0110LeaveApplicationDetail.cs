using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0110LeaveApplicationDetail
{
    public decimal LeaveApplicationId { get; set; }

    public decimal CmpId { get; set; }

    public decimal LeaveId { get; set; }

    public DateTime FromDate { get; set; }

    public DateTime ToDate { get; set; }

    public decimal LeavePeriod { get; set; }

    public string LeaveAssignAs { get; set; } = null!;

    public string? LeaveReason { get; set; }

    public decimal RowId { get; set; }

    public decimal LoginId { get; set; }

    public DateTime SystemDate { get; set; }

    public DateTime? HalfLeaveDate { get; set; }

    public string? LeaveAppDoc { get; set; }

    public DateTime? LeaveOutTime { get; set; }

    public DateTime? LeaveInTime { get; set; }

    public DateTime? LeaveActualOutTime { get; set; }

    public DateTime? LeaveActualInTime { get; set; }

    public decimal NightHalt { get; set; }

    public string? LeaveCompOffDates { get; set; }

    public byte HalfPayment { get; set; }

    public byte WarningFlag { get; set; }

    public byte RulesViolate { get; set; }

    public byte IsImport { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual T0040LeaveMaster Leave { get; set; } = null!;

    public virtual T0100LeaveApplication LeaveApplication { get; set; } = null!;
}
