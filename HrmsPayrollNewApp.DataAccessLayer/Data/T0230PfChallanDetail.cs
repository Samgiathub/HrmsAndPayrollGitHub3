using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0230PfChallanDetail
{
    public decimal PfChallanId { get; set; }

    public decimal CmpId { get; set; }

    public decimal SrNo { get; set; }

    public string PaymentHead { get; set; } = null!;

    public decimal Ac1 { get; set; }

    public decimal Ac2 { get; set; }

    public decimal Ac10 { get; set; }

    public decimal Ac21 { get; set; }

    public decimal Ac22 { get; set; }

    public decimal AcTotal { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual T0220PfChallan PfChallan { get; set; } = null!;
}
