using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0100LeaveCfDetail
{
    public decimal LeaveCfId { get; set; }

    public decimal CmpId { get; set; }

    public decimal EmpId { get; set; }

    public decimal LeaveId { get; set; }

    public DateTime CfForDate { get; set; }

    public DateTime CfFromDate { get; set; }

    public DateTime CfToDate { get; set; }

    public decimal CfPDays { get; set; }

    public decimal CfLeaveDays { get; set; }

    public string CfType { get; set; } = null!;

    public string LeaveName { get; set; } = null!;

    public string? EmpFullName { get; set; }

    public string? AlphaEmpCode { get; set; }

    public decimal BranchId { get; set; }

    public decimal? VerticalId { get; set; }

    public decimal? SubVerticalId { get; set; }

    public decimal? DeptId { get; set; }

    public string LeaveType { get; set; } = null!;

    public decimal? AdvanceLeaveBalance { get; set; }
}
