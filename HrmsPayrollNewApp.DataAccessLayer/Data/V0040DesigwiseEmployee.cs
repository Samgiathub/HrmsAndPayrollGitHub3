using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0040DesigwiseEmployee
{
    public decimal EmpId { get; set; }

    public string? EmpLeft { get; set; }

    public decimal EmpCode { get; set; }

    public string? EmpFullName { get; set; }

    public decimal DesigId { get; set; }

    public decimal DesigDisNo { get; set; }

    public string DesigName { get; set; } = null!;

    public decimal CmpId { get; set; }

    public decimal? ParentId { get; set; }

    public decimal? DefId { get; set; }

    public byte? IsMain { get; set; }

    public decimal BranchId { get; set; }
}
