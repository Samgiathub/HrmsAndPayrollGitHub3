using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0000ResorceTable
{
    public decimal Id { get; set; }

    public string Name { get; set; } = null!;

    public string? English { get; set; }

    public string? Chinese { get; set; }
}
