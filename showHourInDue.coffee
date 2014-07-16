# Skrypt doklejający godziny i minuty do dnia w widoku ogólnym boardu, gdzie task ma ustawiony due date

dane = undefined
czasDoPobraniaDanych = 1000 * 60 * 5
key = '150b027506f6a0aae88a52c67c1a121e'

# Zrób request
# Przeiteruj po taskach z duedate.
pobierzDane = ->
  $.ajax
    url: 'https://trello.com/1/members/my/cards?key='+key+'&token=substitutethispartwiththeauthorizationtokenthatyougotfromtheuser'
    success: (data) ->
      if typeof dane is "undefined"
        data.map (row) ->
          $("a[href='" + row.url.split("trello.com")[1] + "']").next(".badges").find("[class^=badge-state-due]").find(".badge-text").append " " + row.due.split("T")[1].substr(0, 5)  if row.due?
      dane = data

# init
pobierzDane()

# co interwal sprawdzaj, czy nie doszło do aktualizacji due date w kartach
setInterval ->
  pobierzDane()
, czasDoPobraniaDanych

# Po każdej modyfikacji DOMu zrobionym przez trello dopisz ponownie daty
setTimeout ->
  unless typeof dane is "undefined"
    MutationObserver = window.MutationObserver or window.WebKitMutationObserver
    observer = new MutationObserver (mutations, observer) ->

      # console.log mutations, observer
      if $("a[href='" + dane[0].url + "']").next(".badges").find("[class^=badge-state-due]").find(".badge-text").text().indexOf(":") is -1

        dane.map (row) ->
          if row.due?
            posDateHH = row.due.split("T")[1].substr(0, 2)
            posDateMM = row.due.split("T")[1].substr(3, 2)
            # Zmien godzine o 2, aby zgadzala sie z nasza strefa czasowa
            posDateGood = (parseInt(posDateHH) + 2) + ":" + posDateMM
            $("a[href='" + row.url.split("trello.com")[1] + "']").next(".badges").find("[class^=badge-state-due]").find(".badge-text").append " " + posDateGood

    observer.observe $("[class^=badge-state-due]")[0],
      subtree: true
      attributes: true
, 5000