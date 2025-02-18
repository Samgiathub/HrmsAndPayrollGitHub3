using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0050LeaveDetail1
{
    public decimal LeaveId { get; set; }

    public decimal RowId { get; set; }

    public decimal GrdId { get; set; }

    public decimal CmpId { get; set; }

    public decimal LeaveDays { get; set; }

    public string? LeaveCode { get; set; }

    public string? LeaveName { get; set; }

    public string? LeaveCfType { get; set; }

    public string? DefaultShortName { get; set; }

    public decimal? LeaveStatus { get; set; }

    public DateTime? InActiveEffectiveDate { get; set; }

    public decimal BalAfterEncash { get; set; }

    public decimal MaxLeaveEncash { get; set; }

    public decimal MinLeaveEncash { get; set; }

    public decimal MaxNoOfApplication { get; set; }

    public decimal LEncPercentageOfCurrentBalance { get; set; }

    public decimal EncashAppliAfterMonth { get; set; }

    public decimal MinLeaveCf { get; set; }

    public decimal MaxAccumulateBalance { get; set; }

    public decimal MinLeave { get; set; }

    public decimal MaxLeave { get; set; }

    public decimal NoticePeriod { get; set; }

    public string? MultiBranchId { get; set; }

    public string? LeaveType { get; set; }
}
