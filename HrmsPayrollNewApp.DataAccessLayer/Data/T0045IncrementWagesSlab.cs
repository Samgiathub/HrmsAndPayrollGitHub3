using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0045IncrementWagesSlab
{
    public int RowId { get; set; }

    public decimal? CmpId { get; set; }

    public decimal? TranId { get; set; }

    public decimal? FromWages { get; set; }

    public decimal? ToWages { get; set; }

    public decimal? Percentage { get; set; }
}
