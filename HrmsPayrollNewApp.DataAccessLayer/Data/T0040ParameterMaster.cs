using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0040ParameterMaster
{
    public decimal ParaId { get; set; }

    public decimal CmpId { get; set; }

    public string ParaName { get; set; } = null!;

    public string? ParaFor { get; set; }

    public decimal? LoginId { get; set; }

    public DateTime? SystemDate { get; set; }
}
