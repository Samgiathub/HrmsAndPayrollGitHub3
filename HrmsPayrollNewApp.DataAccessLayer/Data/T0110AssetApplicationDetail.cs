using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0110AssetApplicationDetail
{
    public decimal AssetApplicationDetId { get; set; }

    public decimal AssetApplicationId { get; set; }

    public decimal CmpId { get; set; }

    public decimal AssetId { get; set; }

    public decimal? AssetMId { get; set; }

    public string Status { get; set; } = null!;

    public virtual T0040AssetMaster Asset { get; set; } = null!;

    public virtual T0100AssetApplication AssetApplication { get; set; } = null!;

    public virtual T0040AssetDetail? AssetM { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;
}
