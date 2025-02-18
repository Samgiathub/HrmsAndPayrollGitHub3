using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0041ClaimMaxlimitDesign
{
    public decimal TranId { get; set; }

    public decimal ClaimId { get; set; }

    public decimal? DesigId { get; set; }

    public decimal? MaxUnit { get; set; }

    public decimal MaxLimitKm { get; set; }

    public decimal RatePerKm { get; set; }

    public decimal? GradeId { get; set; }

    public decimal? BranchId { get; set; }

    public decimal? UnitId { get; set; }

    public int? AfterJoiningDays { get; set; }

    public double? MinKm { get; set; }

    public virtual T0040ClaimMaster Claim { get; set; } = null!;

    public virtual T0040DesignationMaster? Desig { get; set; }
}
