using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0050LeaveDetail
{
    public string LeaveName { get; set; } = null!;

    public string GrdName { get; set; } = null!;

    public decimal CmpId { get; set; }

    public decimal LeaveDays { get; set; }

    public decimal RowId { get; set; }

    public decimal LeaveId { get; set; }

    public decimal GrdId { get; set; }

    public string? DefaultShortName { get; set; }

    public decimal? LeaveStatus { get; set; }

    public DateTime? InActiveEffectiveDate { get; set; }

    public decimal BalAfterEncash { get; set; }

    public decimal MinLeaveEncash { get; set; }

    public decimal MaxLeaveEncash { get; set; }

    public decimal MaxNoOfApplication { get; set; }

    public decimal LEncPercentageOfCurrentBalance { get; set; }

    public decimal EncashAppliAfterMonth { get; set; }

    public decimal MinLeaveCf { get; set; }

    public decimal MaxAccumulateBalance { get; set; }

    public decimal MinLeave { get; set; }

    public decimal MaxLeave { get; set; }

    public decimal NoticePeriod { get; set; }

    public string? MultiBranchId { get; set; }

    public byte MedicalLeave { get; set; }

    public decimal MaxLeaveApp { get; set; }

    public decimal AfterResumingDuty { get; set; }

    public decimal MaxCfFromLastYrBalance { get; set; }

    public byte EffectSalaryCycle { get; set; }

    public decimal MonthlyMaxLeave { get; set; }

    public int ApplyHourly { get; set; }

    public decimal LeaveSortingNo { get; set; }

    public byte IsProbation { get; set; }
}
