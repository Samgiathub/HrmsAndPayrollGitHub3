using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class TblOrganizationDisplay
{
    public decimal RowId { get; set; }

    public decimal? EmpId { get; set; }

    public string? EmpName { get; set; }

    public decimal? DesigId { get; set; }

    public decimal? DefId { get; set; }

    public decimal? IntLevel { get; set; }

    public decimal? ParentId { get; set; }

    public decimal? TotalMember { get; set; }

    public decimal? IsMain { get; set; }
}
