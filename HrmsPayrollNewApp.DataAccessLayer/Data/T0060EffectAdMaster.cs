using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0060EffectAdMaster
{
    public decimal AdTranId { get; set; }

    public decimal AdId { get; set; }

    public decimal CmpId { get; set; }

    public decimal EffectAdId { get; set; }

    public virtual T0050AdMaster Ad { get; set; } = null!;

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual T0050AdMaster EffectAd { get; set; } = null!;
}
