using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0060RimbEffectAdMaster
{
    public decimal RimbTranId { get; set; }

    public decimal RimbId { get; set; }

    public decimal CmpId { get; set; }

    public decimal AdId { get; set; }

    public virtual T0050AdMaster Ad { get; set; } = null!;

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual T0055Reimbursement Rimb { get; set; } = null!;
}
