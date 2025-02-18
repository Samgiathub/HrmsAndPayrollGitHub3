using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0095ExitCostCenterList
{
    public decimal EmpId { get; set; }

    public string? CenterName { get; set; }

    public string? EmpFullName { get; set; }

    public decimal CmpId { get; set; }

    public string? AlphaEmpCode { get; set; }

    public DateTime? EffectiveDate { get; set; }

    public decimal? CenterId { get; set; }
}
