using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0011LoginEamilDatum
{
    public string? AlphaEmpCode { get; set; }

    public string? EmpFullName { get; set; }

    public string? EmailId { get; set; }

    public string Designation { get; set; } = null!;

    public string? EmpLeft { get; set; }
}
