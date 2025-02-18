using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0050GeneralDetail
{
    public decimal GenTranId { get; set; }

    public decimal CmpId { get; set; }

    public decimal GenId { get; set; }

    public decimal Acc11 { get; set; }

    public decimal Acc12 { get; set; }

    public decimal Acc23 { get; set; }

    public decimal Acc101 { get; set; }

    public decimal Acc211 { get; set; }

    public decimal Acc223 { get; set; }

    public decimal Acc101MaxLimit { get; set; }

    public decimal PfLimit { get; set; }

    public decimal? PfPensionAge { get; set; }

    public decimal? Acc224 { get; set; }

    public int IsNcpProrata { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;
}
