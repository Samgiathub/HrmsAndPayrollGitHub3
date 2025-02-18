using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class SmsTemplate
{
    public string TempId { get; set; } = null!;

    public string? TempName { get; set; }

    public string? TempType { get; set; }

    public string? Header { get; set; }

    public string? Message { get; set; }

    public string? EntityId { get; set; }
}
