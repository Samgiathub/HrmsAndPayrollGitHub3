using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0140TravelSettlementApplication
{
    public decimal TravelSetApplicationId { get; set; }

    public decimal TravelApprovalId { get; set; }

    public decimal CmpId { get; set; }

    public decimal EmpId { get; set; }

    public decimal AdvanceAmount { get; set; }

    public decimal Expence { get; set; }

    public decimal Credit { get; set; }

    public decimal Debit { get; set; }

    public string? Comment { get; set; }

    public string? Document { get; set; }

    public DateTime ForDate { get; set; }

    public byte VisitedFlag { get; set; }

    public string Status { get; set; } = null!;

    public byte DirectEntry { get; set; }

    public string? Oddates { get; set; }

    public string? TourAgendaActual { get; set; }

    public string? ImpBusinessAppointActual { get; set; }

    public string? KraTourActual { get; set; }

    public decimal? TravelTypeId { get; set; }
}
