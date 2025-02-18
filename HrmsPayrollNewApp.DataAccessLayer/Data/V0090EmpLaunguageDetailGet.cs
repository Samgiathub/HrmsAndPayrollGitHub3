using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0090EmpLaunguageDetailGet
{
    public decimal RowId { get; set; }

    public decimal EmpId { get; set; }

    public decimal CmpId { get; set; }

    public decimal LangId { get; set; }

    public string LangFluency { get; set; } = null!;

    public string? LangAbility { get; set; }

    public string LangName { get; set; } = null!;
}
