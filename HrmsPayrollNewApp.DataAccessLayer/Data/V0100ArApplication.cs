using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0100ArApplication
{
    public decimal ArAppId { get; set; }

    public decimal CmpId { get; set; }

    public decimal EmpId { get; set; }

    public decimal GrdId { get; set; }

    public DateTime ForDate { get; set; }

    public decimal? EligibileAmount { get; set; }

    public decimal? TotalAmount { get; set; }

    public decimal? AppStatus { get; set; }

    public decimal CreatedBy { get; set; }

    public DateTime DateCreated { get; set; }

    public decimal? Modifiedby { get; set; }

    public DateTime? DateModified { get; set; }

    public string? EmpFullNameNew { get; set; }

    public decimal? BranchId { get; set; }

    public decimal? VerticalId { get; set; }

    public decimal? SubVerticalId { get; set; }

    public decimal? DeptId { get; set; }
}
