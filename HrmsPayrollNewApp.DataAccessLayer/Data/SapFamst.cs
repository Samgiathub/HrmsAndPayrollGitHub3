using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class SapFamst
{
    public int FamstId { get; set; }

    public string? Famst { get; set; }

    public string? Description { get; set; }

    public string? Alias { get; set; }
}
