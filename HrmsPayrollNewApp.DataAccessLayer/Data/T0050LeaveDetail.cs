using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0050LeaveDetail
{
    public decimal LeaveId { get; set; }

    public decimal RowId { get; set; }

    public decimal GrdId { get; set; }

    public decimal CmpId { get; set; }

    public decimal LeaveDays { get; set; }

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

    public decimal MaxLeaveApp { get; set; }

    public decimal AfterResumingDuty { get; set; }

    public decimal MaxCfFromLastYrBalance { get; set; }

    public byte EffectSalaryCycle { get; set; }

    public decimal MonthlyMaxLeave { get; set; }

    public byte IsProbation { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual T0040GradeMaster Grd { get; set; } = null!;

    public virtual T0040LeaveMaster Leave { get; set; } = null!;
}
