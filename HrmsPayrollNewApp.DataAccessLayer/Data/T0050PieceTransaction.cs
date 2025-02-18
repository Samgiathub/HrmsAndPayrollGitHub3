using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0050PieceTransaction
{
    public decimal PieceTranId { get; set; }

    public decimal? EmpId { get; set; }

    public decimal? CmpId { get; set; }

    public decimal? ProductId { get; set; }

    public decimal? SubProductId { get; set; }

    public decimal? PieceTransCount { get; set; }

    public DateTime? PieceTransDate { get; set; }
}
