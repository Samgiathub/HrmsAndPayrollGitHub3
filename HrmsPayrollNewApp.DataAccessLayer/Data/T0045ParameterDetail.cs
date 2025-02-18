using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0045ParameterDetail
{
    public decimal RowId { get; set; }

    public decimal CmpId { get; set; }

    public decimal ParaId { get; set; }

    public decimal? FromSlab { get; set; }

    public decimal? ToSlab { get; set; }

    public decimal? SlabValue { get; set; }

    public string? ParaName { get; set; }

    public string? ParaFor { get; set; }

    public virtual T0040ParameterMaster Para { get; set; } = null!;
}
