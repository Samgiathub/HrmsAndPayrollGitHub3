using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0130BondInstallmentDetail
{
    public decimal InstallmentId { get; set; }

    public decimal CmpId { get; set; }

    public decimal EmpId { get; set; }

    public decimal? BondId { get; set; }

    public decimal BondAprId { get; set; }

    public DateTime? EffectiveDate { get; set; }

    public decimal? InstallmentAmt { get; set; }

    public DateTime? SystemDate { get; set; }

    public virtual T0120BondApproval BondApr { get; set; } = null!;
}
