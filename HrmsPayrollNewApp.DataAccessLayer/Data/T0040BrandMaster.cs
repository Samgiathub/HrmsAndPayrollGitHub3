using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0040BrandMaster
{
    public decimal BrandId { get; set; }

    public decimal CmpId { get; set; }

    public string BrandName { get; set; } = null!;

    public string? BrandDesc { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual ICollection<T0040AssetDetail> T0040AssetDetails { get; set; } = new List<T0040AssetDetail>();
}
