using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0050AdMasterReimEffectGet
{
    public string AdName { get; set; } = null!;

    public decimal AdId { get; set; }

    public string AdSortName { get; set; } = null!;

    public decimal AdLevel { get; set; }

    public decimal? RimbId { get; set; }

    public int AdChecked { get; set; }

    public decimal CmpId { get; set; }
}
