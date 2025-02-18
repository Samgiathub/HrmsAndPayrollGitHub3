using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class SendLog
{
    public decimal Id { get; set; }

    public string? Mobile { get; set; }

    public string? Sendtext { get; set; }

    public string? Response { get; set; }

    public string? Created { get; set; }

    public DateTime? Createddate { get; set; }
}
