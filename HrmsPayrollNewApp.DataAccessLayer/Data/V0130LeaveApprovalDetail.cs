using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0130LeaveApprovalDetail
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

    public string? LeaveName { get; set; }

    public decimal? LeaveApplicationId { get; set; }

    public decimal? EmpId { get; set; }

    public string? ApprovalStatus { get; set; }

    public string? LeaveCompOffDates { get; set; }

    public byte WarningFlag { get; set; }

    public byte RulesViolate { get; set; }
}
