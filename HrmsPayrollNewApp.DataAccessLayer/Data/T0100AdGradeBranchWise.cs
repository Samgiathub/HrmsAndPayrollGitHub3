using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0100AdGradeBranchWise
{
    public decimal TranId { get; set; }

    public decimal? CmpId { get; set; }

    public decimal? AdId { get; set; }

    public string? AdCalculateOn { get; set; }

    public DateTime? EffectiveDate { get; set; }

    public decimal? GrdId { get; set; }

    public decimal? BranchId { get; set; }

    public decimal? AdAmount { get; set; }

    public DateTime? SysDatetime { get; set; }

    public decimal? UserId { get; set; }

    public virtual T0050AdMaster? Ad { get; set; }

    public virtual T0030BranchMaster? Branch { get; set; }

    public virtual T0040GradeMaster? Grd { get; set; }
}
