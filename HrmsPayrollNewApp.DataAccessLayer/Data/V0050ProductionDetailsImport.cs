using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0050ProductionDetailsImport
{
    public decimal TranId { get; set; }

    public decimal? CmpId { get; set; }

    public decimal? ProductionMonth { get; set; }

    public decimal? ProductionYear { get; set; }

    public decimal? ProductionPcs { get; set; }

    public decimal? ProductionAmount { get; set; }

    public decimal? IncentiveAmount { get; set; }

    public decimal? CardAmount { get; set; }

    public decimal? GrossAmount { get; set; }

    public decimal EmpId { get; set; }

    public string? EmpFullName { get; set; }

    public string? AlphaEmpCode { get; set; }

    public decimal BranchId { get; set; }

    public decimal? VerticalId { get; set; }
}
