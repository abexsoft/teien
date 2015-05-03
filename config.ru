require_relative './apps/routes'

Faye::WebSocket.load_adapter('thin')

run Routes