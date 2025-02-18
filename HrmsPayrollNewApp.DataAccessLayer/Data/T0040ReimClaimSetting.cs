using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0040ReimClaimSetting
{
    public decimal TranId { get; set; }

    public decimal CmpId { get; set; }

    public decimal AdId { get; set; }

    public decimal? NonTaxableLimit { get; set; }

    public decimal? TaxableLimit { get; set; }

    public decimal? NumLtaBlock { get; set; }

    public byte? IsCf { get; set; }

    public virtual T0050AdMaster Ad { get; set; } = null!;

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;
}
