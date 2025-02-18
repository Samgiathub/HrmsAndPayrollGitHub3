using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0210MonthlyBondPayment
{
    public decimal BondPayId { get; set; }

    public decimal BondAprId { get; set; }

    public decimal CmpId { get; set; }

    public decimal? SalTranId { get; set; }

    public decimal BondPayAmount { get; set; }

    public string BondPayComments { get; set; } = null!;

    public DateTime BondPaymentDate { get; set; }

    public virtual T0120BondApproval BondApr { get; set; } = null!;

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;
}
