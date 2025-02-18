using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0190EmpIncentiveImport
{
    public decimal TranId { get; set; }

    public decimal? CmpId { get; set; }

    public decimal? EmpId { get; set; }

    public decimal? BranchId { get; set; }

    public decimal? DesigId { get; set; }

    public string? ParaName { get; set; }

    public decimal? ParaValue { get; set; }

    public string? ParaType { get; set; }

    public decimal? ParaId { get; set; }

    public DateTime? ForDate { get; set; }

    public decimal? LoginId { get; set; }

    public DateTime? SystemDate { get; set; }

    public string? Formula { get; set; }
}
