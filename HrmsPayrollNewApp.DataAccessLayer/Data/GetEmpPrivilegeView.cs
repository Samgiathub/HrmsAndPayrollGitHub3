using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class GetEmpPrivilegeView
{
    public decimal? TranId { get; set; }

    public decimal PrivilageId { get; set; }

    public decimal CmpId { get; set; }

    public decimal FormId { get; set; }

    public int? IsView { get; set; }

    public int? IsEdit { get; set; }

    public int? IsSave { get; set; }

    public int? IsDelete { get; set; }

    public int? IsPrint { get; set; }

    public string FormName { get; set; } = null!;

    public decimal UnderFormId { get; set; }

    public string? ModuleName { get; set; }

    public string? PageFlag { get; set; }
}
