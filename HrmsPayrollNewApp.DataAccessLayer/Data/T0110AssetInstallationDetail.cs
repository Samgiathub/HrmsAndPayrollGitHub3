using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0110AssetInstallationDetail
{
    public decimal AssetInstallationDetId { get; set; }

    public decimal CmpId { get; set; }

    public decimal AssetMId { get; set; }

    public decimal AssetInstallationId { get; set; }

    public string InstallationDetails { get; set; } = null!;

    public decimal? EmpId { get; set; }

    public decimal? AssetApprovalId { get; set; }

    public int? BranchId { get; set; }

    public int? DeptId { get; set; }

    public virtual T0120AssetApproval? AssetApproval { get; set; }

    public virtual T0030AssetInstallation AssetInstallation { get; set; } = null!;

    public virtual T0040AssetDetail AssetM { get; set; } = null!;

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual T0080EmpMaster? Emp { get; set; }
}
