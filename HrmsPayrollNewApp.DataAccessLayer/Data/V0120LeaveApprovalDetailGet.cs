using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0120LeaveApprovalDetailGet
{
    public decimal LeaveApprovalId { get; set; }

    public decimal? LeaveApplicationId { get; set; }

    public decimal CmpId { get; set; }

    public decimal EmpId { get; set; }

    public decimal? SEmpId { get; set; }

    public DateTime ApprovalDate { get; set; }

    public string ApprovalStatus { get; set; } = null!;

    public string ApprovalComments { get; set; } = null!;

    public decimal LoginId { get; set; }

    public DateTime SystemDate { get; set; }

    public DateTime? FromDate { get; set; }

    public decimal? LeaveId { get; set; }

    public DateTime? ToDate { get; set; }

    public decimal? LeavePeriod { get; set; }

    public string? LeaveAssignAs { get; set; }

    public string? LeaveReason { get; set; }

    public string? LeaveName { get; set; }

    public string? EmpFullName { get; set; }

    public decimal? RowId { get; set; }
}
