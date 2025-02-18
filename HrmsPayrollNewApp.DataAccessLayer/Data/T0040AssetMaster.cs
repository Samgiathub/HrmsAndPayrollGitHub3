using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0040AssetMaster
{
    public decimal AssetId { get; set; }

    public decimal CmpId { get; set; }

    public string AssetName { get; set; } = null!;

    public string? AssetDesc { get; set; }

    public string? Code { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual ICollection<T0030AssetInstallation> T0030AssetInstallations { get; set; } = new List<T0030AssetInstallation>();

    public virtual ICollection<T0040AssetDetail> T0040AssetDetails { get; set; } = new List<T0040AssetDetail>();

    public virtual ICollection<T0090EmpAssetDetail> T0090EmpAssetDetails { get; set; } = new List<T0090EmpAssetDetail>();

    public virtual ICollection<T0110AssetApplicationDetail> T0110AssetApplicationDetails { get; set; } = new List<T0110AssetApplicationDetail>();
}
