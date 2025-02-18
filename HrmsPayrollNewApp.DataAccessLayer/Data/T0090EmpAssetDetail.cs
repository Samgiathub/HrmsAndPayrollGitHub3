using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0090EmpAssetDetail
{
    public decimal EmpAssetId { get; set; }

    public decimal CmpId { get; set; }

    public decimal EmpId { get; set; }

    public decimal AssetId { get; set; }

    public string ModelNo { get; set; } = null!;

    public DateTime IssueDate { get; set; }

    public DateTime? ReturnDate { get; set; }

    public string? AssetComment { get; set; }

    public virtual T0040AssetMaster Asset { get; set; } = null!;

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual T0080EmpMaster Emp { get; set; } = null!;
}
