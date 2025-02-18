using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0180Bonu
{
    public string? EmpFirstName { get; set; }

    public string? EmpFullName { get; set; }

    public string? BranchName { get; set; }

    public DateTime FromDate { get; set; }

    public DateTime ToDate { get; set; }

    public string? BonusCalculatedOn { get; set; }

    public decimal? BonusAmount { get; set; }

    public decimal BonusId { get; set; }

    public decimal EmpId { get; set; }

    public decimal? BonusCalculatedAmount { get; set; }

    public decimal BonusPercentage { get; set; }

    public decimal BonusFixAmount { get; set; }

    public string? BonusComments { get; set; }

    public decimal BonusEffectYear { get; set; }

    public decimal BonusEffectMonth { get; set; }

    public decimal BonusEffectOnSal { get; set; }

    public decimal CmpId { get; set; }

    public string? EmpCode { get; set; }

    public decimal? VerticalId { get; set; }

    public decimal? SubVerticalId { get; set; }

    public decimal? DeptId { get; set; }

    public decimal? CatId { get; set; }

    public decimal GrdId { get; set; }

    public decimal? DesigId { get; set; }

    public decimal? TypeId { get; set; }

    public decimal BranchId { get; set; }

    public string? BonusCalType { get; set; }

    public string BonusCalculatedOn1 { get; set; } = null!;
}
