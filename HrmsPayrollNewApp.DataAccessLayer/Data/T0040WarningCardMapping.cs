using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0040WarningCardMapping
{
    public decimal CmpId { get; set; }

    public decimal LevelTranId { get; set; }

    public decimal LevelId { get; set; }

    public string LevelName { get; set; } = null!;

    public decimal NoOfCard { get; set; }

    public string CardColor { get; set; } = null!;

    public decimal LoginId { get; set; }

    public DateTime SystemDate { get; set; }
}
