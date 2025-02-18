using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0090EmpAssetDetailClone
{
    public decimal EmpAssetId { get; set; }

    public decimal CmpId { get; set; }

    public decimal EmpId { get; set; }

    public decimal AssetId { get; set; }

    public string ModelNo { get; set; } = null!;

    public DateTime IssueDate { get; set; }

    public DateTime? ReturnDate { get; set; }

    public string? AssetComment { get; set; }

    public DateTime SystemDate { get; set; }

    public decimal LoginId { get; set; }
}
