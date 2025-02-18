using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0100AssetApplication
{
    public decimal AssetApplicationId { get; set; }

    public decimal CmpId { get; set; }

    public decimal EmpId { get; set; }

    public decimal BranchId { get; set; }

    public DateTime ApplicationDate { get; set; }

    public string ApplicationCode { get; set; } = null!;

    public string AssetId { get; set; } = null!;

    public string Remarks { get; set; } = null!;

    public decimal LoginId { get; set; }

    public DateTime SystemDate { get; set; }

    public string? ApplicationStatus { get; set; }

    public decimal? ApplicationType { get; set; }

    public string? AssetMId { get; set; }

    public decimal? DeptId { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual ICollection<T0110AssetApplicationDetail> T0110AssetApplicationDetails { get; set; } = new List<T0110AssetApplicationDetail>();
}
