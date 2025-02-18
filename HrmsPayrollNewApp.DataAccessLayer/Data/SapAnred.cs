using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class SapAnred
{
    public int AnredId { get; set; }

    public string? Anred { get; set; }

    public string? Description { get; set; }

    public string? Alias { get; set; }
}
