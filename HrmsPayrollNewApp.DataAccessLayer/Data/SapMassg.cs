using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class SapMassg
{
    public int MassnId { get; set; }

    public string? Massn { get; set; }

    public string? Massg { get; set; }

    public string? Description { get; set; }

    public string? Alias { get; set; }
}
