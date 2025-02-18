using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0180Bonu
{
    public decimal BonusId { get; set; }

    public decimal CmpId { get; set; }

    public decimal EmpId { get; set; }

    public DateTime FromDate { get; set; }

    public DateTime ToDate { get; set; }

    public string BonusCalculatedOn { get; set; } = null!;

    public decimal BonusPercentage { get; set; }

    public decimal BonusAmount { get; set; }

    public decimal BonusFixAmount { get; set; }

    public decimal BonusEffectOnSal { get; set; }

    public decimal BonusEffectMonth { get; set; }

    public decimal BonusEffectYear { get; set; }

    public string? BonusComments { get; set; }

    public decimal? BonusCalculatedAmount { get; set; }

    public byte? IsFnf { get; set; }

    public decimal? ExGratiaCalculatedAmount { get; set; }

    public decimal? ExGratiaBonusAmount { get; set; }

    public decimal PunjaOtherCustBonusPaid { get; set; }

    public decimal IntrimeAdvanceBonusPaid { get; set; }

    public decimal DeductionMisAmount { get; set; }

    public decimal IncomeTaxOnBonus { get; set; }

    public decimal NetPayableBonus { get; set; }

    public string? BonusCalType { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual T0080EmpMaster Emp { get; set; } = null!;

    public virtual ICollection<T0190BonusDetail> T0190BonusDetails { get; set; } = new List<T0190BonusDetail>();
}
