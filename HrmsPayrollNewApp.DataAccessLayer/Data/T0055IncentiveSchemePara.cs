using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0055IncentiveSchemePara
{
    public decimal SchemeId { get; set; }

    public decimal ParaId { get; set; }

    public decimal RowId { get; set; }

    public string ParaName { get; set; } = null!;

    public decimal FromSlab { get; set; }

    public decimal ToSlab { get; set; }

    public decimal SlabValue { get; set; }

    public string? PFormula { get; set; }

    public string? ParaFor { get; set; }
}
