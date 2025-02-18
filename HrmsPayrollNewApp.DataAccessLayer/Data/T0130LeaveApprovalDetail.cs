using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0130LeaveApprovalDetail
{
    public decimal LeaveApprovalId { get; set; }

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

    public int? IsImport { get; set; }

    public byte MCancelWoHo { get; set; }

    public DateTime? HalfLeaveDate { get; set; }

    public DateTime? LeaveOutTime { get; set; }

    public DateTime? LeaveInTime { get; set; }

    public decimal NightHalt { get; set; }

    public string? LeaveCompOffDates { get; set; }

    public byte HalfPayment { get; set; }

    public byte WarningFlag { get; set; }

    public byte RulesViolate { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual T0040LeaveMaster Leave { get; set; } = null!;

    public virtual T0120LeaveApproval LeaveApproval { get; set; } = null!;
}
